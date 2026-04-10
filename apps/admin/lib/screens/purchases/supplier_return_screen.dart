import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

/// شاشة مرتجعات المشتريات للمورد
/// تتيح إرجاع بضاعة لمورد مع إصدار إشعار خصم
class SupplierReturnScreen extends ConsumerStatefulWidget {
  const SupplierReturnScreen({super.key});

  @override
  ConsumerState<SupplierReturnScreen> createState() =>
      _SupplierReturnScreenState();
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

  List<(String, String)> _reasons(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      ('damaged', l10n.damagedDefective),
      ('wrong_item', l10n.wrongItem),
      ('expired', l10n.expiredProduct),
      ('overstock', l10n.overstockExcess),
      ('other', l10n.otherReason),
    ];
  }

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
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        setState(() {
          _error = AppLocalizations.of(context).storeNotSelected;
          _isLoading = false;
        });
        return;
      }
      final sups = await db.suppliersDao.getAllSuppliers(storeId);
      if (mounted) {
        setState(() {
          _suppliers =
              sups.map((s) => _SupplierOption(id: s.id, name: s.name)).toList();
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

  void _addItem() {
    showDialog(
      context: context,
      builder: (ctx) {
        String productName = '';
        double qty = 1;
        double unitCost = 0;
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.addItemForReturn),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.itemName,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => productName = v,
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: l10n.quantityLabel,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => qty = double.tryParse(v) ?? 1,
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: l10n.unitPrice,
                        border: const OutlineInputBorder(),
                        suffixText: l10n.sarSuffix,
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
              child: Text(l10n.cancel),
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
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReturn() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.pleaseSelectSupplier),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.pleaseAddItems),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmReturn),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.supplierLabel(_selectedSupplier!.name)),
            Text(l10n.itemCount(_items.length)),
            Text(l10n.totalAmount(_totalReturn.toStringAsFixed(2))),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              l10n.creditNoteWillBeRecorded,
              style:
                  TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirmReturn),
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
              l10n.returnRecordedSuccess(_totalReturn.toStringAsFixed(2)),
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
          SnackBar(
              content: Text(l10n.errorPrefix(e.toString(), e)),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.supplierReturns)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.supplierReturns)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AlhaiSpacing.sm),
              Text(_error!),
              TextButton(
                  onPressed: _loadSuppliers, child: Text(l10n.retryAction)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.supplierReturns),
        actions: [
          if (!_isSaving)
            TextButton.icon(
              onPressed: _submitReturn,
              icon: const Icon(Icons.check_rounded),
              label: Text(l10n.issueCreditNote),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.textOnPrimary),
            )
          else
            const Padding(
              padding: EdgeInsets.all(AlhaiSpacing.sm),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: AppColors.textOnPrimary, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        children: [
          // Supplier selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.supplier,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AlhaiSpacing.xs),
                  DropdownButtonFormField<_SupplierOption>(
                    initialValue: _selectedSupplier,
                    decoration: InputDecoration(
                      hintText: l10n.selectSupplier,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.business_rounded),
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
          const SizedBox(height: AlhaiSpacing.sm),

          // Return reason
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.returnReason,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _reasons(context)
                        .map((r) => ChoiceChip(
                              label: Text(r.$2,
                                  style: const TextStyle(fontSize: 12)),
                              selected: _returnReason == r.$1,
                              onSelected: (_) =>
                                  setState(() => _returnReason = r.$1),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),

          // Items
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.returnedItems(_items.length),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: Text(l10n.addItem),
                      ),
                    ],
                  ),
                  if (_items.isEmpty)
                    AppEmptyState.noProducts(context, onAdd: _addItem)
                  else
                    ...(_items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return ListTile(
                        dense: true,
                        leading:
                            const Icon(Icons.inventory_2_rounded, size: 20),
                        title: Text(item.productName),
                        subtitle: Text(
                          '${item.qty} × ${item.unitCost.toStringAsFixed(2)} ${l10n.sarSuffix}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(item.qty * item.unitCost).toStringAsFixed(2)} ${l10n.sarSuffix}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.error),
                              onPressed: () =>
                                  setState(() => _items.removeAt(i)),
                            ),
                          ],
                        ),
                      );
                    })),
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),

          // Notes
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              hintText: l10n.additionalNotesHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.notes_rounded),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AlhaiSpacing.mdl),

          // Total
          if (_items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              decoration: BoxDecoration(
                gradient: AppColors.getErrorGradient(
                    Theme.of(context).brightness == Brightness.dark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.totalReturn,
                      style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold)),
                  Text(
                    '${_totalReturn.toStringAsFixed(2)} ${l10n.sarSuffix}',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
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
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.textOnPrimary),
                    )
                  : const Icon(Icons.assignment_return_rounded),
              label: Text(l10n
                  .issueCreditNoteWithAmount(_totalReturn.toStringAsFixed(0))),
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
  const _ReturnItem(
      {required this.productName, required this.qty, required this.unitCost});
}
