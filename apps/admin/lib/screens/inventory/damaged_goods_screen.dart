import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

/// شاشة البضاعة التالفة والمفقودة
class DamagedGoodsScreen extends ConsumerStatefulWidget {
  const DamagedGoodsScreen({super.key});

  @override
  ConsumerState<DamagedGoodsScreen> createState() => _DamagedGoodsScreenState();
}

class _DamagedGoodsScreenState extends ConsumerState<DamagedGoodsScreen> {
  bool _isLoading = true;
  String _period = 'month';
  List<_DamagedRecord> _records = [];
  double _totalLoss = 0;

  final _lossTypes = [
    ('damaged', 'تالف / معيب', Icons.broken_image_rounded, Colors.red),
    ('expired', 'منتهي الصلاحية', Icons.event_busy_rounded, Colors.orange),
    ('theft', 'سرقة / فقدان', Icons.security_rounded, Colors.purple),
    ('waste', 'هدر / كسر', Icons.delete_rounded, Colors.brown),
  ];

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

      final result = await db.customSelect(
        '''SELECT
             im.id,
             im.type,
             im.qty,
             im.note,
             im.created_at,
             p.name as product_name,
             p.cost_price,
             (ABS(im.qty) * COALESCE(p.cost_price, 0)) as loss_amount
           FROM inventory_movements im
           LEFT JOIN products p ON p.id = im.product_id
           WHERE im.store_id = ?
             AND im.type IN ('waste', 'damaged', 'expired', 'theft', 'supplier_return')
             AND im.created_at >= ?
             AND im.created_at < ?
           ORDER BY im.created_at DESC''',
        variables: [
          Variable.withString(storeId),
          Variable.withDateTime(dr.start),
          Variable.withDateTime(dr.end),
        ],
      ).get();

      if (mounted) {
        final records = result.map((row) => _DamagedRecord(
          id: row.data['id'] as String,
          type: row.data['type'] as String,
          productName: row.data['product_name'] as String? ?? 'منتج غير محدد',
          qty: _toDouble(row.data['qty']).abs(),
          lossAmount: _toDouble(row.data['loss_amount']),
          note: row.data['note'] as String? ?? '',
          date: _parseDate(row.data['created_at']),
        )).toList();

        setState(() {
          _records = records;
          _totalLoss = records.fold(0.0, (sum, r) => sum + r.lossAmount);
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

  DateTime _parseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  void _showRecordDialog() {
    String productName = '';
    String lossType = 'damaged';
    double qty = 1;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('تسجيل بضاعة تالفة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => productName = v,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'الكمية',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => qty = double.tryParse(v) ?? 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'التكلفة/وحدة',
                          border: OutlineInputBorder(),
                          suffixText: 'ر.س',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('نوع الخسارة', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: _lossTypes.map((t) => ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.$3, size: 14, color: lossType == t.$1 ? Colors.white : t.$4),
                        const SizedBox(width: 4),
                        Text(t.$2, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    selected: lossType == t.$1,
                    onSelected: (_) => setDlg(() => lossType = t.$1),
                    selectedColor: t.$4,
                  )).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () async {
                if (productName.trim().isEmpty) return;
                Navigator.pop(ctx);
                try {
                  final db = GetIt.I<AppDatabase>();
                  final storeId = ref.read(currentStoreIdProvider)!;
                  await db.customStatement(
                    '''INSERT INTO inventory_movements
                       (id, store_id, product_id, type, qty, note, created_at)
                       VALUES (?, ?, NULL, ?, ?, ?, ?)''',
                    [
                      const Uuid().v4(),
                      storeId,
                      lossType,
                      -qty,
                      '${noteController.text} - $productName',
                      DateTime.now().toIso8601String(),
                    ],
                  );
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تسجيل البضاعة التالفة بنجاح'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('تسجيل'),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getTypeInfo(String type) {
    for (final t in _lossTypes) {
      if (t.$1 == type) return (t.$3, t.$4);
    }
    return (Icons.warning_rounded, Theme.of(context).colorScheme.outline);
  }

  @override
  Widget build(BuildContext context) {
    final byType = <String, double>{};
    for (final r in _records) {
      byType[r.type] = (byType[r.type] ?? 0) + r.lossAmount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('البضاعة التالفة والمفقودة'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) { setState(() => _period = v); _loadData(); },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'week', child: Text('هذا الأسبوع')),
              const PopupMenuItem(value: 'month', child: Text('هذا الشهر')),
              const PopupMenuItem(value: 'year', child: Text('هذه السنة')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Text('الفترة'),
                Icon(Icons.arrow_drop_down),
              ]),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Loss summary
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.withValues(alpha: 0.05),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي الخسائر',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          Text(
                            '${_totalLoss.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // By type breakdown
                      Row(
                        children: _lossTypes.map((t) {
                          final amount = byType[t.$1] ?? 0;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                children: [
                                  Icon(t.$3, size: 18, color: t.$4),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${amount.toStringAsFixed(0)} ر.س',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: t.$4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(t.$2,
                                      style: TextStyle(fontSize: 9, color: Theme.of(context).hintColor),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _records.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                              const SizedBox(height: 12),
                              Text('لا توجد بضاعة تالفة في هذه الفترة',
                                  style: TextStyle(color: Theme.of(context).hintColor)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _records.length,
                          itemBuilder: (ctx, i) {
                            final r = _records[i];
                            final typeInfo = _getTypeInfo(r.type);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: typeInfo.$2.withValues(alpha: 0.1),
                                  child: Icon(typeInfo.$1, color: typeInfo.$2, size: 20),
                                ),
                                title: Text(r.productName,
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الكمية: ${r.qty.toStringAsFixed(0)} | '
                                      '${r.date.day}/${r.date.month}/${r.date.year}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    if (r.note.isNotEmpty)
                                      Text(r.note,
                                          style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                                  ],
                                ),
                                trailing: Text(
                                  '${r.lossAmount.toStringAsFixed(0)} ر.س',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: typeInfo.$2,
                                    fontSize: 13,
                                  ),
                                ),
                                isThreeLine: r.note.isNotEmpty,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRecordDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('تسجيل بضاعة تالفة'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _DamagedRecord {
  final String id;
  final String type;
  final String productName;
  final double qty;
  final double lossAmount;
  final String note;
  final DateTime date;
  const _DamagedRecord({
    required this.id,
    required this.type,
    required this.productName,
    required this.qty,
    required this.lossAmount,
    required this.note,
    required this.date,
  });
}
