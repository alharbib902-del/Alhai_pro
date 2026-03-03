import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:uuid/uuid.dart';

/// شاشة مرتجعات المشتريات للمورد
/// تتيح إرجاع بضاعة لمورد مع إصدار إشعار خصم
class SupplierReturnScreen extends ConsumerStatefulWidget {
  const SupplierReturnScreen({super.key});

  @override
  ConsumerState<SupplierReturnScreen> createState() => _SupplierReturnScreenState();
}

class _SupplierReturnScreenState extends ConsumerState<SupplierReturnScreen> {
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;

  List<_SupplierOption> _suppliers = [];
  _SupplierOption? _selectedSupplier;
  final List<_ReturnItem> _items = [];

  final _noteController = TextEditingController();
  String _returnReason = 'damaged';

  final _reasons = const [
    ('damaged', 'تالف / معيب'),
    ('wrong_item', 'صنف خاطئ'),
    ('expired', 'منتهي الصلاحية'),
    ('overstock', 'فائض عن الحاجة'),
    ('other', 'سبب آخر'),
  ];

  double get _totalReturn =>
      _items.fold(0.0, (sum, i) => sum + (i.qty * i.unitCost));

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() { _error = 'لم يتم تحديد المتجر'; _isLoading = false; });
        return;
      }
      final sups = await db.suppliersDao.getAllSuppliers(storeId);
      if (mounted) {
        setState(() {
          _suppliers = sups.map((s) => _SupplierOption(id: s.id, name: s.name)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (ctx) {
        String productName = '';
        double qty = 1;
        double unitCost = 0;
        return AlertDialog(
          title: const Text('إضافة صنف للإرجاع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'اسم الصنف',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'سعر الوحدة',
                        border: OutlineInputBorder(),
                        suffixText: 'ر.س',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => unitCost = double.tryParse(v) ?? 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (productName.trim().isNotEmpty) {
                  setState(() {
                    _items.add(_ReturnItem(
                      productName: productName.trim(),
                      qty: qty,
                      unitCost: unitCost,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReturn() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('يرجى اختيار المورد'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('يرجى إضافة أصناف للإرجاع'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الإرجاع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المورد: ${_selectedSupplier!.name}'),
            Text('عدد الأصناف: ${_items.length}'),
            Text('الإجمالي: ${_totalReturn.toStringAsFixed(2)} ر.س'),
            const SizedBox(height: 8),
            Text(
              'سيتم تسجيل إشعار خصم وتعديل المخزون.',
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد الإرجاع'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider)!;
      final returnId = const Uuid().v4();
      final now = DateTime.now();

      // Record as inventory movements (waste/return type)
      for (final item in _items) {
        await db.customStatement(
          '''INSERT INTO inventory_movements
             (id, store_id, product_id, type, qty, note, reference_id, created_at)
             VALUES (?, ?, NULL, 'supplier_return', ?, ?, ?, ?)''',
          [
            const Uuid().v4(),
            storeId,
            -item.qty,
            '$_returnReason: ${item.productName}',
            returnId,
            now.toIso8601String(),
          ],
        );
      }

      // Update supplier account balance
      await db.customStatement(
        '''UPDATE accounts SET
           balance = balance - ?,
           last_transaction_at = ?
           WHERE store_id = ? AND type = 'payable'
             AND name LIKE ?''',
        [
          _totalReturn,
          now.toIso8601String(),
          storeId,
          '%${_selectedSupplier!.name}%',
        ],
      );

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تسجيل المرتجع بنجاح - إشعار خصم: ${_totalReturn.toStringAsFixed(2)} ر.س',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('مرتجعات المشتريات')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('مرتجعات المشتريات')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!),
              TextButton(onPressed: _loadSuppliers, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('مرتجعات المشتريات'),
        actions: [
          if (!_isSaving)
            TextButton.icon(
              onPressed: _submitReturn,
              icon: const Icon(Icons.check_rounded),
              label: const Text('إصدار إشعار خصم'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            )
          else
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Supplier selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المورد', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<_SupplierOption>(
                    initialValue: _selectedSupplier,
                    decoration: const InputDecoration(
                      hintText: 'اختر المورد',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    items: _suppliers
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSupplier = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Return reason
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('سبب الإرجاع', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _reasons.map((r) => ChoiceChip(
                      label: Text(r.$2, style: const TextStyle(fontSize: 12)),
                      selected: _returnReason == r.$1,
                      onSelected: (_) => setState(() => _returnReason = r.$1),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Items
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الأصناف المرتجعة',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('إضافة صنف'),
                      ),
                    ],
                  ),
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('لم تتم إضافة أصناف بعد',
                            style: TextStyle(color: Theme.of(context).hintColor)),
                      ),
                    )
                  else
                    ...(_items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.inventory_2_rounded, size: 20),
                        title: Text(item.productName),
                        subtitle: Text(
                          '${item.qty} × ${item.unitCost.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(item.qty * item.unitCost).toStringAsFixed(2)} ر.س',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              onPressed: () => setState(() => _items.removeAt(i)),
                            ),
                          ],
                        ),
                      );
                    })),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Notes
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'ملاحظات',
              hintText: 'أي ملاحظات إضافية...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_rounded),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          // Total
          if (_items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي المرتجع',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                    '${_totalReturn.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _submitReturn,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.assignment_return_rounded),
              label: Text('إصدار إشعار خصم (${_totalReturn.toStringAsFixed(0)} ر.س)'),
            )
          : null,
    );
  }
}

class _SupplierOption {
  final String id;
  final String name;
  const _SupplierOption({required this.id, required this.name});

  @override
  bool operator ==(Object other) => other is _SupplierOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class _ReturnItem {
  final String productName;
  final double qty;
  final double unitCost;
  const _ReturnItem({required this.productName, required this.qty, required this.unitCost});
}
